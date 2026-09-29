resource "aws_cloudtrail" "this" {
  #checkov:skip=CKV_AWS_35:A customer managed key costs money. The log archive already encrypts with SSE-S3.
  #checkov:skip=CKV2_AWS_10:CloudWatch Logs ingestion is billed. Logs stay in S3 and can be queried there.
  #checkov:skip=CKV_AWS_252:Nothing would subscribe to delivery notifications. Delivery is visible in S3.
  name           = local.trail_name
  s3_bucket_name = aws_s3_bucket.log_archive.id

  is_multi_region_trail         = true
  include_global_service_events = true

  enable_log_file_validation = true

  advanced_event_selector {
    name = "All management events"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  dynamic "advanced_event_selector" {
    for_each = var.enable_s3_data_events && length(var.data_event_bucket_arns) > 0 ? [1] : []
    content {
      name = "Object writes in data buckets"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = ["AWS::S3::Object"]
      }

      field_selector {
        field  = "readOnly"
        equals = ["false"]
      }

      field_selector {
        field       = "resources.ARN"
        starts_with = [for arn in var.data_event_bucket_arns : "${arn}/"]
      }
    }
  }

  depends_on = [aws_s3_bucket_policy.log_archive]
}
