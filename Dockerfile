FROM amazoncorretto:26

WORKDIR /app

# Copy Java source file
COPY HelloWorld.java .

# Compile inside container
RUN javac HelloWorld.java

# Run the compiled class
CMD ["java", "HelloWorld"]
