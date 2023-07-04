package kube

service: minio: spec: ports: [{
	port: 9000
	name: "minio-s3"
}, {
	port: 9090
	name: "minio-console"
}]
