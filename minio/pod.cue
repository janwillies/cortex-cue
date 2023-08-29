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
            /usr/bin/mc alias set local http://minio.default.svc:9000 minioadmin minioadmin;

            echo "Waiting for minio to launch on 9000...";
            while ! nc -z minio.default.svc 9000; do sleep 0.1; done;

            /usr/bin/mc mb local/cortex;
            # /usr/bin/mc tree local/;
            """,
        ]
    }]
}