*** Settings ***
Documentation    Workload Keywords

Library    Collections
Library    String
Library    ../libs/keywords/common_keywords.py
Library    ../libs/keywords/volume_keywords.py
Library    ../libs/keywords/workload_keywords.py
Library    ../libs/keywords/host_keywords.py
Library    ../libs/keywords/k8s_keywords.py

*** Keywords ***
Keep writing data to pod of ${workload_kind} ${workload_id}
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    keep_writing_workload_pod_data    ${workload_name}

Power off volume node of ${workload_kind} ${workload_id} for ${duration} minutes
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    reboot_volume_node    ${volume_name}    ${duration}

Reboot volume node of ${workload_kind} ${workload_id}
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    reboot_volume_node    ${volume_name}

Stop volume node kubelet of ${workload_kind} ${workload_id} for ${duration} seconds
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    ${node_name} =    get_volume_node    ${volume_name}
    restart_kubelet    ${node_name}    ${duration}

Stop volume nodes kubelet for ${duration} seconds
    [Arguments]    @{args}
    @{node_list} =    Create List
    FOR    ${arg}    IN    @{args}
        @{workload} =    Split String    ${arg}
        ${workload_name} =    generate_name_with_suffix    ${workload}[0]    ${workload}[1]
        ${volume_name} =    get_workload_volume_name    ${workload_name}
        ${node_name} =    get_volume_node    ${volume_name}
        Append To List    ${node_list}    ${node_name}
    END
    restart_kubelet_on_nodes    ${duration}    ${node_list}

Wait for volume of ${workload_kind} ${workload_id} healthy
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    wait_for_workload_volume_healthy    ${workload_name}

Wait until volume of ${workload_kind} ${workload_id} replica rebuilding started on ${replica_locality}
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    wait_for_replica_rebuilding_to_start_on_node    ${volume_name}    ${replica_locality}

Wait for volume of ${workload_kind} ${workload_id} attached and unknown
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    wait_for_volume_unknown    ${volume_name}

Wait for volume of ${workload_kind} ${workload_id} attached and degraded
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    wait_for_volume_degraded    ${volume_name}

Wait for volume of ${workload_kind} ${workload_id} attached and healthy
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    wait_for_volume_healthy    ${volume_name}

Wait for volume of ${workload_kind} ${workload_id} attached to the original node and degraded
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    wait_for_volume_degraded    ${volume_name}
    ${volume_node} =    get_volume_node    ${volume_name}
    Should Be Equal    ${last_volume_node}    ${volume_node}

Wait for volume of ${workload_kind} ${workload_id} attached to another node and degraded
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    wait_for_volume_degraded    ${volume_name}
    ${volume_node} =    get_volume_node    ${volume_name}
    Should Not Be Equal    ${last_volume_node}    ${volume_node}

Delete replica of ${workload_kind} ${workload_id} volume on ${replica_locality}
    ${workload_name} =   generate_name_with_suffix    ${workload_kind}    ${workload_id}
    ${volume_name} =    get_workload_volume_name    ${workload_name}
    delete_replica_on_node    ${volume_name}    ${replica_locality}

Wait for workloads pods stable
    [Arguments]    @{args}
    @{workload_list} =    Create List
    FOR    ${arg}    IN    @{args}
        @{workload} =    Split String    ${arg}
        ${workload_name} =    generate_name_with_suffix    ${workload}[0]    ${workload}[1]
        Append To List    ${workload_list}    ${workload_name}
    END
    wait_for_workloads_pods_stably_running    ${workload_list}
