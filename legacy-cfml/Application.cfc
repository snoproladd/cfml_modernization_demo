component {

    this.name = "YardCheckInLegacy";
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0);

    // Connection settings come from environment variables set in docker-compose.yml.
    // Postgres support is bundled with Lucee, so no admin setup is needed.
    this.datasources["yard"] = {
        class: "org.postgresql.Driver",
        bundleName: "org.postgresql.jdbc",
        connectionString: "jdbc:postgresql://#server.system.environment.DB_HOST#:#server.system.environment.DB_PORT#/#server.system.environment.DB_NAME#",
        username: server.system.environment.DB_USER,
        password: server.system.environment.DB_PASSWORD
    };

// Every query uses this datasource unless told otherwise.
    this.datasource = "yard";

    // TODO (you): add onRequestStart / onError handlers as you learn them.
}
