import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_ROLE_ID")
supabase: Client = create_client(url, key)

# Geocoding data to seed
locations = [
    {"name": "Mall of Asia", "latitude": 14.5352, "longitude": 120.9822},
    {"name": "Makati", "latitude": 14.5547, "longitude": 121.0244},
    {"name": "BGC", "latitude": 14.5500, "longitude": 121.0494},
    {"name": "Quezon City", "latitude": 14.6760, "longitude": 121.0437},
    {"name": "Manila", "latitude": 14.5995, "longitude": 120.9842},
    {"name": "San Fernando Pampanga", "latitude": 15.0333, "longitude": 120.6833},
    {"name": "San Fernando La Union", "latitude": 16.6159, "longitude": 120.3209},
    {"name": "Angeles City", "latitude": 15.1450, "longitude": 120.5887},
    {"name": "Holy Angel University", "latitude": 15.1450, "longitude": 120.5887},
    {"name": "Clark", "latitude": 15.1789, "longitude": 120.5323},
    {"name": "Baguio", "latitude": 16.4124, "longitude": 120.5999},
    {"name": "Davao", "latitude": 7.1907, "longitude": 125.4553},
    {"name": "Cebu", "latitude": 10.3157, "longitude": 123.8854},
    {"name": "Tagaytay", "latitude": 14.1153, "longitude": 120.9621},
    {"name": "Batangas", "latitude": 13.7565, "longitude": 121.0583},
    {"name": "Laguna", "latitude": 14.3122, "longitude": 121.1114},
]

def seed_geocoding():
    print(f"Seeding {len(locations)} locations to Supabase...")
    
    for loc in locations:
        try:
            # Check if exists
            res = supabase.table("geocoding_data").select("*").eq("name", loc["name"]).execute()
            
            if not res.data:
                supabase.table("geocoding_data").insert(loc).execute()
                print(f"✅ Added: {loc['name']}")
            else:
                print(f"⏭️ Skipping (exists): {loc['name']}")
        except Exception as e:
            print(f"❌ Error adding {loc['name']}: {e}")

if __name__ == "__main__":
    seed_geocoding()
