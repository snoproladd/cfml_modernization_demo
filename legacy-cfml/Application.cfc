component {

    this.name = "YardCheckInLegacy";
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0);
    this.timezone="America/New_York";

    this.datasources["yard"] = {
        class: "org.postgresql.Driver",
        bundleName: "org.postgresql.jdbc",
        connectionString: "jdbc:postgresql://#server.system.environment.DB_HOST#:#server.system.environment.DB_PORT#/#server.system.environment.DB_NAME#",
        username: server.system.environment.DB_USER,
        password: server.system.environment.DB_PASSWORD
    };

    this.datasource = "yard";
}
