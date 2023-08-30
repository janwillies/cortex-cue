package kube

pod: "minio-bucket-creator": spec: {
    restartPolicy: "Never"
    containers: [{
        image: "alpine:3.18"
        command: [ "/bin/sh" ]
        args: [
            "-c",
            """
            # set -x;
            set -o pipefail;

            apk add --no-cache --update curl;

            arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/);
            curl -L -o /usr/bin/mc https://dl.min.io/client/mc/release/linux-${arch}/mc;
            chmod +x /usr/bin/mc;

            echo "Waiting for minio to launch on 9000...";\n
            """ +
            "while ! nc -z minio." + k8s.namespace + ".svc 9000; do sleep 0.1; done;\n\n" +
            "/usr/bin/mc alias set local http://minio." + k8s.namespace + ".svc:9000 minioadmin minioadmin;\n" + 
            """
            /usr/bin/mc mb local/cortex;
            # /usr/bin/mc tree local/;
            """,
        ]
    }]
}