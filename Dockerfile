# BUILD_IMAGE
FROM maven:3.6-jdk-8-slim as BUILD_IMAGE

ENV VERS=0.0.5

RUN mkdir -p /triplifier

COPY lib/ /triplifier/lib/
COPY conf/ /triplifier/conf/
COPY data/ /triplifier/data/
COPY db/ /triplifier/db/
COPY src/ /triplifier/src/
COPY pom.xml /triplifier/pom.xml

RUN mvn -f /triplifier/pom.xml package

# APP
FROM openjdk:8-jre-alpine
RUN apk add dos2unix

ENV VERS=0.0.5

RUN mkdir -p /usr/share/triplifier && \
mkdir -p /usr/share/triplifier/target/DUMP

WORKDIR /usr/share/triplifier

COPY conf/ /usr/share/triplifier/conf/
COPY data/ /usr/share/triplifier/data/
COPY db/ /usr/share/triplifier/db/
COPY src/main/swagger-ui /usr/share/triplifier/src/main/swagger-ui

COPY --from=BUILD_IMAGE /triplifier/target/libs /usr/share/triplifier/libs
COPY --from=BUILD_IMAGE /triplifier/target/triplifier-${VERS}.jar /usr/share/triplifier/triplifier.jar

RUN chmod 755 /usr/share/triplifier -R
RUN find . -type f -print0 | xargs -0 dos2unix > /dev/null

EXPOSE 7777
ENTRYPOINT ["/usr/bin/java", "-cp", "/usr/share/triplifier/libs/*:/usr/share/triplifier/triplifier.jar", "triplifier.main.MainHTTPTriplifier"]
