# Stage 1: Build WAR with Maven + JDK 21
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# Stage 2: Run on Apache Tomcat 10.1 (Jakarta EE 10 + JDK 21)
FROM tomcat:10.1-jdk21-temurin

WORKDIR /usr/local/tomcat

# Remove default Tomcat webapps and deploy as ROOT.war (serves cleanly at "/")
RUN rm -rf webapps/*
COPY --from=builder /app/target/CourseShop.war webapps/ROOT.war

# Trust Render/Cloud reverse proxy X-Forwarded-Proto & X-Forwarded-For headers
RUN sed -i 's|<Valve className="org.apache.catalina.valves.AccessLogValve"|<Valve className="org.apache.catalina.valves.RemoteIpValve" protocolHeader="X-Forwarded-Proto" remoteIpHeader="X-Forwarded-For" />\n        <Valve className="org.apache.catalina.valves.AccessLogValve"|' conf/server.xml

# Bind to Render's $PORT (defaults to 8080 locally)
EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/\" conf/server.xml && exec catalina.sh run"]
