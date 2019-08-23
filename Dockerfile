FROM alpine/git as clone 
WORKDIR /app
RUN git clone https://github.com/paulvassu/adidasChallenge

FROM gradle:5.6.0-jdk8 as builder
COPY --from=clone --chown=gradle:gradle ./app/adidasChallenge /home/gradle/src
WORKDIR /home/gradle/src
RUN ./gradlew build
RUN gradle test

FROM openjdk:8u222-jre-slim
EXPOSE 8080
WORKDIR /app
COPY --from=builder /home/gradle/src/build/libs/challenge-0.0.1.jar /app
CMD java -jar challenge-0.0.1.jar
