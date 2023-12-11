# Use the official Flutter Docker image as a base
FROM cirrusci/flutter:stable

# Copy your app's source code to the container
COPY . /app/

# Set the working directory
WORKDIR /app/

# Run the Flutter web build command
RUN flutter pub get
RUN flutter build web