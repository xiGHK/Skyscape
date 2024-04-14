import pandas as pd

# Read the CSV file
data = pd.read_csv("mrt_lrt_data.csv")

# Convert to dictionary
mrt_stations = {}
for _, row in data.iterrows():
    mrt_stations[row["station_name"]] = [row["lat"], row["lng"]]

sorted_mrt_stations = dict(sorted(mrt_stations.items()))

# Print the sorted dictionary
print(sorted_mrt_stations.keys())
