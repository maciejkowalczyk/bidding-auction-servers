# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_monitoring_dashboard" "environment_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "${var.environment} Buyer Metrics",
  "mosaicLayout": {
    "columns": 48,
    "tiles": [
      {
        "height": 19,
        "widget": {
          "title": "request.count [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/request.count\" resource.type=\"generic_task\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24
      },
      {
        "height": 19,
        "widget": {
          "title": "request.failed_count [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/request.failed_count\" resource.type=\"generic_task\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "xPos": 24
      },
      {
        "height": 19,
        "widget": {
          "title": "system.cpu.percent [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/system.cpu.percent\" resource.type=\"generic_task\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "yPos": 76
      },
      {
        "height": 19,
        "widget": {
          "title": "request.duration_ms [95TH PERCENTILE]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_PERCENTILE_95",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_DELTA"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/request.duration_ms\" resource.type=\"generic_task\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "xPos": 24,
        "yPos": 19
      },
      {
        "height": 19,
        "widget": {
          "title": "system.memory.usage_kb for main process [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/system.memory.usage_kb\" resource.type=\"generic_task\" metric.label.\"label\"=\"main process\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "yPos": 57
      },
      {
        "height": 19,
        "widget": {
          "title": "system.memory.usage_kb for MemAvailable: [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "metric.label.\"label\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/system.memory.usage_kb\" resource.type=\"generic_task\" metric.label.\"label\"=\"MemAvailable:\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "xPos": 24,
        "yPos": 57
      },
      {
        "height": 19,
        "widget": {
          "title": "request.size_bytes [95TH PERCENTILE]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_PERCENTILE_95",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_DELTA"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/request.size_bytes\" resource.type=\"generic_task\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "yPos": 38
      },
      {
        "height": 19,
        "widget": {
          "title": "response.size_bytes [95TH PERCENTILE]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_PERCENTILE_95",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_DELTA"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/response.size_bytes\" resource.type=\"generic_task\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "xPos": 24,
        "yPos": 38
      },
      {
        "height": 19,
        "widget": {
          "title": "js_execution.duration_ms [95TH PERCENTILE]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_PERCENTILE_95",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_DELTA"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/js_execution.duration_ms\" resource.type=\"generic_task\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "yPos": 19
      },
      {
        "height": 19,
        "widget": {
          "title": "initiated_request.count [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/initiated_request.count\" resource.type=\"generic_task\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "xPos": 24,
        "yPos": 76
      },
      {
        "height": 19,
        "widget": {
          "title": "initiated_request.errors_count [MEAN]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/initiated_request.errors_count\" resource.type=\"generic_task\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "yPos": 95
      },
      {
        "height": 19,
        "widget": {
          "title": "initiated_request.duration_ms [95TH PERCENTILE]",
          "xyChart": {
            "chartOptions": {},
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_PERCENTILE_95",
                      "groupByFields": [
                        "metric.label.\"service_name\"",
                        "metric.label.\"deployment_environment\"",
                        "resource.label.\"task_id\""
                      ],
                      "perSeriesAligner": "ALIGN_DELTA"
                    },
                    "filter": "metric.type=\"workload.googleapis.com/initiated_request.duration_ms\" resource.type=\"generic_task\""
                  }
                }
              }
            ],
            "yAxis": {
              "scale": "LINEAR"
            }
          }
        },
        "width": 24,
        "xPos": 24,
        "yPos": 95
      }
    ]
  }
}
EOF
}
