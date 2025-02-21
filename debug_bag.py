import rosbag2_py

# Open the ROS 2 bag
reader = rosbag2_py.SequentialReader()
reader.open("/data/slam_data/ros2/jsu-01", rosbag2_py.StorageOptions(uri="path_to_rosbag", storage_id="sqlite3"), rosbag2_py.ConverterOptions())

# Read messages and calculate time differences
prev_timestamp = None
for topic, msg, timestamp in reader:
    if prev_timestamp is not None:
        time_diff = (timestamp - prev_timestamp) / 1e9  # Convert nanoseconds to seconds
        print(f"Time difference: {time_diff:.6f} seconds")
    prev_timestamp = timestamp
