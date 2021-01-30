import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {

	//--------------------------------------------------

	// In case hostname is set via environment.
	if let hostname = Environment.get("HOSTNAME") {
		app.http.server.configuration.hostname = hostname
	}
	else if app.environment == .production {
		app.http.server.configuration.hostname = "0.0.0.0"
	}

	// In case port is set via environment.
	// For example, if deploying to Heroku, use this.
	if let port = Environment.get("PORT").flatMap(Int.init) {
		app.http.server.configuration.port = port
	}

	//--------------------------------------------------

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	/*
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateTodo())
	*/

    // register routes
    try routes(app)

	//--------------------------------------------------
}
