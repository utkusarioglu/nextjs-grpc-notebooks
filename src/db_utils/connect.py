import yaml
from .vault_connect.connect import VaultConnect
from .postgres_connect.connect import PostgresConnect


class DbConnect:
    def __init__(self, vault_connect_config_path: str, vault_role_config_path: str):
        self.vault_connect_config_path = vault_connect_config_path
        self.vault_role_config_path = vault_role_config_path

    def _retrieve_connection_config(self):
        with open(self.vault_connect_config_path, "r") as stream:
            try:
                config = yaml.safe_load(stream)
                return config
            except yaml.YAMLError as error:
                print("Vault connection config retrieval error:")
                print(error)

    def _retrieve_role_config(self):
        with open(self.vault_role_config_path, "r") as stream:
            try:
                config = yaml.safe_load(stream)
                return config
            except yaml.YAMLError as error:
                print("Vault role config retrieval error")
                print(error)

    def create_db_connection(self, vault_path: str, db_name: str):
        connection_config = self._retrieve_connection_config()
        role_config = self._retrieve_role_config()
        if not connection_config:
            raise ValueError("Connection config is needed")
        if not role_config:
            raise ValueError("Role configuration is needed")
        vault = VaultConnect(
            connection_config["vault"]["fqdn"],
            connection_config["vault"]["port"],
            connection_config["vault"]["certPath"],
            role_config["vault"]["username"],
            role_config["vault"]["password"],
        )
        db_creds = vault.get_db_creds(vault_path)
        postgres_connection = PostgresConnect(
            connection_config["postgresql"]["host"],
            connection_config["postgresql"]["port"],
            db_name,
            # role_config["postgresql"]["db_name"],
            db_creds["username"],
            db_creds["password"],
        )
        return postgres_connection
