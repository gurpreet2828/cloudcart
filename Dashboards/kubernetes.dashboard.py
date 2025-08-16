from grafanalib.core import (
    Dashboard, Row, Stat, Graph, Target, Gauge, Time, Legend, YAxis, XAxis,
    BYTES_FORMAT, SHORT_FORMAT, NO_FORMAT, Pixels
)

datasource = "prometheus"

dashboard = Dashboard(
    title="Kubernetes Pod Resources",
    time=Time("now-3h", "now"),
    timezone="browser",
    rows=[
        Row(
            title="All Pods",
            showTitle=True,
            height=Pixels(180),
            panels=[
                Stat(
                    title="Memory Working Set",
                    dataSource=datasource,
                    format="percent",
                    thresholds="65,90",
                    span=4,
                    colorValue=True,
                    targets=[
                        Target(
                            expr='sum(container_memory_working_set_bytes{id="/"}) / sum(machine_memory_bytes) * 100',
                            refId="A",
                        ),
                    ],
                    gauge=Gauge(minValue=0, maxValue=100, show=True),
                ),
                Stat(
                    title="CPU Usage",
                    dataSource=datasource,
                    format="percent",
                    thresholds="65,90",
                    decimals=2,
                    span=4,
                    colorValue=True,
                    targets=[
                        Target(
                            expr='sum(rate(container_cpu_usage_seconds_total{id="/"}[1m])) / sum(machine_cpu_cores) * 100',
                            refId="A",
                        ),
                    ],
                    gauge=Gauge(minValue=0, maxValue=100, show=True),
                ),
                Stat(
                    title="Filesystem Usage",
                    dataSource=datasource,
                    format="percent",
                    thresholds="65,90",
                    decimals=2,
                    span=4,
                    colorValue=True,
                    targets=[
                        Target(
                            expr='sum(container_fs_usage_bytes{id="/"}) / sum(container_fs_limit_bytes{id="/"}) * 100',
                            refId="A",
                        ),
                    ],
                    gauge=Gauge(minValue=0, maxValue=100, show=True),
                ),
                Stat(
                    title="Memory Used",
                    dataSource=datasource,
                    format="bytes",
                    decimals=2,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(container_memory_working_set_bytes{id="/"})',
                            refId="A",
                        ),
                    ],
                ),
                Stat(
                    title="Memory Total",
                    dataSource=datasource,
                    format="bytes",
                    decimals=2,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(machine_memory_bytes)',
                            refId="A",
                        ),
                    ],
                ),
                Stat(
                    title="CPU Used",
                    dataSource=datasource,
                    format=NO_FORMAT,
                    decimals=2,
                    span=2,
                    postfix=" cores",
                    targets=[
                        Target(
                            expr='sum(rate(container_cpu_usage_seconds_total{id="/"}[1m]))',
                            refId="A",
                        ),
                    ],
                ),
                Stat(
                    title="CPU Total",
                    dataSource=datasource,
                    format=NO_FORMAT,
                    decimals=2,
                    span=2,
                    postfix=" cores",
                    targets=[
                        Target(
                            expr='sum(machine_cpu_cores)',
                            refId="A",
                        ),
                    ],
                ),
                Stat(
                    title="Filesystem Used",
                    dataSource=datasource,
                    format=BYTES_FORMAT,
                    decimals=2,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(container_fs_usage_bytes{id="/"})',
                            refId="A",
                        ),
                    ],
                ),
                Stat(
                    title="Filesystem Total",
                    dataSource=datasource,
                    format=BYTES_FORMAT,
                    decimals=2,
                    span=2,
                    targets=[
                        Target(
                            expr='sum(container_fs_limit_bytes{id="/"})',
                            refId="A",
                        ),
                    ],
                ),
                Graph(
                    title="Network",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(rate(container_network_receive_bytes_total[1m]))',
                            legendFormat="receive",
                            refId='A',
                        ),
                        Target(
                            expr='-sum(rate(container_network_transmit_bytes_total[1m]))',
                            legendFormat="transmit",
                            refId='B',
                        ),
                    ],
                    yAxes=[
                        YAxis(format="Bps", show=True, label="transmit / receive"),
                        YAxis(format="Bps", show=False),
                    ],
                ),
            ],
        ),
        Row(
            title="Each Pod",
            showTitle=True,
            height=Pixels(250),
            panels=[
                Graph(
                    title="CPU Usage",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(rate(container_cpu_usage_seconds_total{image!="",name=~"^k8s_.*"}[1m])) by (pod_name)',
                            legendFormat="{{ pod_name }}",
                            refId='A',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format=NO_FORMAT, label="cores"),
                        YAxis(format=NO_FORMAT, label="cores"),
                    ],
                ),
                Graph(
                    title="Memory Working Set",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(container_memory_working_set_bytes{image!="",name=~"^k8s_.*"}) by (pod_name)',
                            legendFormat="{{ pod_name }}",
                            refId='A',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format=BYTES_FORMAT, label="used"),
                        YAxis(format=BYTES_FORMAT, label="used"),
                    ],
                ),
                Graph(
                    title="Network",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(rate(container_network_receive_bytes_total{image!="",name=~"^k8s_.*"}[1m])) by (pod_name)',
                            legendFormat="{{ pod_name }} < in",
                            refId='A',
                        ),
                        Target(
                            expr='-sum(rate(container_network_transmit_bytes_total{image!="",name=~"^k8s_.*"}[1m])) by (pod_name)',
                            legendFormat="{{ pod_name }} > out",
                            refId='B',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format="Bps", label="transmit / receive"),
                        YAxis(format=SHORT_FORMAT),
                    ],
                ),
                Graph(
                    title="Filesystem",
                    dataSource=datasource,
                    span=12,
                    legend=Legend(
                        show=True,
                        alignAsTable=True,
                        rightSide=True,
                        avg=True,
                        current=True,
                    ),
                    targets=[
                        Target(
                            expr='sum(container_fs_usage_bytes{image!="",name=~"^k8s_.*"}) by (pod_name)',
                            legendFormat="{{ pod_name }}",
                            refId='A',
                        ),
                    ],
                    xAxis=XAxis(mode="time"),
                    yAxes=[
                        YAxis(format=BYTES_FORMAT, label="used"),
                        YAxis(format=SHORT_FORMAT),
                    ],
                ),
            ],
        ),
    ],
).auto_panel_ids()
