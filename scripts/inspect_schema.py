import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_ROLE_ID")
supabase: Client = create_client(url, key)

def inspect_table(table_name):
    try:
        res = supabase.table(table_name).select("*").limit(1).execute()
        if res.data:
            print(f"Schema for {table_name}:")
            print(res.data[0].keys())
        else:
            print(f"No data in {table_name}")
    except Exception as e:
        print(f"Error inspecting {table_name}: {e}")

if __name__ == "__main__":
    inspect_table("smart_trips")
