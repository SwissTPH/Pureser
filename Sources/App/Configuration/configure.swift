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

	//--------------------------------------------------

	let psqlConfigFactory: DatabaseConfigurationFactory

	// In case `POSTGRESQL_URL` var is provided by env.
	if
		let psqlURL = Environment.get("POSTGRESQL_URL").flatMap(URL.init),
		let _psqlConfigFactory: DatabaseConfigurationFactory = try? .postgres(url: psqlURL)
	{
		psqlConfigFactory = _psqlConfigFactory
	}
	// In case `DATABASE_URL` var is provided by env (e.g. in case of Heroku for the attached db).
	else if
		let psqlURL = Environment.get("DATABASE_URL").flatMap(URL.init),
		let _psqlConfigFactory: DatabaseConfigurationFactory = try? .postgres(url: psqlURL)
	{
		psqlConfigFactory = _psqlConfigFactory
	}
	// In case of heroku and Heroku Postgres's standard plan.
	// Unverified TLS is required if you are using Heroku Postgres's standard plan.
	else if
		let databaseURL = Environment.get("DATABASE_URL"),
		var postgresConfig = PostgresConfiguration(url: databaseURL)
	{
		postgresConfig.tlsConfiguration = .forClient(certificateVerification: .none)
		psqlConfigFactory = .postgres(configuration: postgresConfig)
	}
	// In case db config vars are provided apart (not as URL) by env.
	else if
		let psqlHostname = Environment.get("POSTGRESQL_HOST"),
		let psqlPortString = Environment.get("POSTGRESQL_PORT"),
		let psqlUsername = Environment.get("POSTGRESQL_USERNAME"),
		let psqlPassword = Environment.get("POSTGRESQL_PASSWORD"),
		let psqlSchema = Environment.get("POSTGRESQL_DATABASE")
	{
		psqlConfigFactory = .postgres(
			hostname: psqlHostname,
			port: Int(psqlPortString)!,
			username: psqlUsername,
			password: psqlPassword,
			database: psqlSchema
		)
	}
	// Otherwise, throw error.
	else {
		print("Fatal Error: 61/07-02.")
		fatalError("Can not configure database. Required env vars not provided.")
	}

	app.databases.use(psqlConfigFactory, as: .psql)

	//--------------------------------------------------

    // register routes
    try routes(app)

	//--------------------------------------------------

	//
	let migrations: [Migration] = [
		Settings.Feature.fileConversionLog ? FileConversionLog.Create() : nil,
	].compactMap { $0 }

	//
	app.migrations.add(migrations)

	// Whether to auto migrate or not.
	// It will auto migrate in non-production environments.
	if true || app.environment != .production {
		try app.autoMigrate().wait()
	}

	//--------------------------------------------------
}
