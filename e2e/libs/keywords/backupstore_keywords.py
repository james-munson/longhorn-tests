from backupstore import Nfs, Minio
from utility.utility import get_longhorn_client
from utility.utility import get_backupstore
from kubernetes import client
from setting import Setting


class backupstore_keywords:

    def __init__(self):
        backupstore = get_backupstore()
        if backupstore.startswith("s3"):
            self.backupstore = Minio()
        elif backupstore.startswith("nfs"):
            self.backupstore = Nfs()
        self.setting = Setting()

    def set_backupstore(self):
        self.setting.set_backupstore()

    def cleanup_backupstore(self):
        if get_backupstore():
            client = get_longhorn_client()
            self.backupstore.cleanup_system_backups(client)
            self.backupstore.cleanup_backup_volumes(client)
            self.setting.reset_backupstore()

    def create_dummy_in_progress_backup(self, volume_name):
        client = get_longhorn_client()
        core_api = client.CoreV1Api()

        dummy_backup_cfg_data = {"Name": "dummy_backup",
                                 "VolumeName": volume_name,
                                 "CreatedTime": ""}

        self.backupstore.write_backup_cfg_file(client,
                                               core_api,
                                               volume_name,
                                               "backup-dummy",
                                               dummy_backup_cfg_data)

    def delete_dummy_in_progress_backup(self, volume_name):
        client = get_longhorn_client()
        core_api = client.CoreV1Api()
        self.backupstore.delete_backup_cfg_file(client,
                                                core_api,
                                                volume_name,
                                                "backup-dummy")

    def corrupt_backup_cfg_file(self, volume_name, backup_name):
        client = get_longhorn_client()
        core_api = client.CoreV1Api()

        corrupt_backup_cfg_data = "{corrupt: definitely"

        self.backupstore.write_backup_cfg_file(client,
                                               core_api,
                                               volume_name,
                                               backup_name,
                                               corrupt_backup_cfg_data)
