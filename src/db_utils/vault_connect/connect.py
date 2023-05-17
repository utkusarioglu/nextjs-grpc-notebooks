import requests

VAULT_USERPASS_ENDPOINT = "v1/auth/userpass/login"


class VaultConnect:
    def __init__(
        self,
        vault_fqdn: str,
        vault_port: int,
        cert_path: str,
        vault_username: str,
        vault_password: str,
    ):
        self.vault_fqdn = vault_fqdn
        self.vault_port = vault_port
        self.vault_url = f"{self.vault_fqdn}:{self.vault_port}"
        self.cert_path = cert_path
        self.vault_username = vault_username
        self.vault_password = vault_password

    def _request_client_token(self):
        """Requests the vault client token using the userpass login method"""
        url = "/".join(
            [
                self.vault_url,
                VAULT_USERPASS_ENDPOINT,
                self.vault_username,
            ]
        )
        token_response = requests.post(
            url,
            {"password": self.vault_password},
            verify=self.cert_path,
        ).json()
        if "errors" in token_response.keys():
            print("Token response error:")
            print("\n".join(token_response["errors"]))
            raise ValueError("client token unavailable")
        return token_response

    def _request_db_creds(self, client_token: str, vault_db_path: str, entity_id: str):
        """Requests the credentials for the given db and role from Vault"""
        url = "/".join([self.vault_url, "v1", vault_db_path, "creds", entity_id])
        db_creds_response = requests.get(
            url,
            headers={"X-Vault-Token": client_token},
            verify=self.cert_path,
        ).json()
        if "errors" in db_creds_response.keys():
            print("Db credential response error:")
            print("\n".join(db_creds_response["errors"]))
            raise ValueError("Error retrieving db credentials")
        db_creds = db_creds_response["data"]
        return db_creds

    def get_db_creds(self, vault_db_path: str):
        """Connects to vault server through the connection config
        given in the configuration yaml file. Returns the db connection
        credentials.
        """
        client_token_response = self._request_client_token()
        db_creds = self._request_db_creds(
            client_token_response["auth"]["client_token"],
            vault_db_path,
            self.vault_username,
        )
        return db_creds
