# import csv
import pandas as pd
import psycopg2
from sqlalchemy import create_engine


class PostgresConnect:
    def __init__(
        self, db_host: str, db_port: int, db_name: str, username: str, password: str
    ) -> None:
        self.host = db_host
        self.port = db_port
        self.db_name = db_name
        self.username = username
        self.password = password

    def db_connection(self):
        """Creates a database connection"""
        engine = create_engine(
            f"postgresql+psycopg2://{self.username}:{self.password}@{self.host}:{self.port}/{self.db_name}"
        )
        return engine.connect()

    def query(self, query_string: str):
        """Queries the database with the given query_string"""
        with self.db_connection() as conn:
            return pd.read_sql_query(query_string, conn)
