package kube

import yaml656e63 "encoding/yaml"

configMap: cortex: data: {
	"config.yaml": yaml656e63.Marshal(_cue_config_yaml)
	let _cue_config_yaml = {
		// Configuration for running Cortex in single-process mode.
		// This should not be used in production.  It is only for getting started
		// and development.

		target: "alertmanager,all"

		auth_enabled: true

		server: {
			http_listen_port: 9009

			// Configure the server to allow messages up to 100MB.
			grpc_server_max_recv_msg_size:      104857600
			grpc_server_max_send_msg_size:      104857600
			grpc_server_max_concurrent_streams: 1000

			log_level: "debug"
		}

		distributor: {
			shard_by_all_labels: true
			pool: health_check_ingesters: true
		}

		ingester_client: grpc_client_config: {
			// Configure the client to allow messages up to 100MB.
			max_recv_msg_size: 104857600
			max_send_msg_size: 104857600
			grpc_compression:  "gzip"
		}

		ingester: lifecycler: {
			// The address to advertise for this ingester.  Will be autodiscovered by
			// looking up address on eth0 or en0; can be specified if this fails.
			// address: 127.0.0.1
			// We want to start immediately and flush on shutdown.
			min_ready_duration: "0s"
			final_sleep:        "0s"
			num_tokens:         512

			// Use an in memory ring store, so we don't need to launch a Consul.
			ring: {
				kvstore: store: "inmemory"
				replication_factor: 1
			}
		}

		blocks_storage: {
			tsdb: dir: "/tmp/cortex/tsdb"

			bucket_store: sync_dir: "/tmp/cortex/tsdb-sync"

			// You can choose between local storage and Amazon S3, Google GCS and Azure storage. Each option requires additional configuration
			// as shown below. All options can be configured via flags as well which might be handy for secret inputs.
			backend: "filesystem" // s3, gcs, azure or filesystem are valid options
			// backend: "s3" // s3, gcs, azure or filesystem are valid options
			// s3: {
			// 	endpoint: "minio:9000"
			// 	secret_access_key: "minioadmin"
			// 	access_key_id:     "minioadmin"
			// 	insecure: true
			// 	bucket_name: "cortex"
			// }
			//  gcs:
			//    bucket_name: cortex
			//    service_account: # if empty or omitted Cortex will use your default service account as per Google's fallback logic
			//  azure:
			//    account_name:
			//    account_key:
			//    container_name:
			//    endpoint_suffix:
			//    max_retries: # Number of retries for recoverable errors (defaults to 20)
			filesystem: {
				dir: "./data/tsdb"
			}
		}

		compactor: {
			data_dir: "/tmp/cortex/compactor"
			sharding_ring: kvstore: store: "inmemory"
		}

		frontend_worker: match_max_concurrent: true

		alertmanager: {
			enable_api: true
			// data_dir: "/data/"
			external_url: "http://localhost"
		}

		alertmanager_storage: {
			backend: "s3"
			s3: {
				endpoint:          "minio."+ k8s.namespace + ".svc:9000"
				secret_access_key: "minioadmin"
				access_key_id:     "minioadmin"
				insecure:          true
				bucket_name:       bucketName
			}
		}

		ruler: enable_api: true

		ruler_storage: {
			backend: "s3"
			s3: {
				endpoint:          "minio."+ k8s.namespace + ".svc:9000"
				secret_access_key: "minioadmin"
				access_key_id:     "minioadmin"
				insecure:          true
				bucket_name:       bucketName
			}
			// backend: "local"
			// local: directory: "/tmp/cortex/rules"
		}
	}
}
