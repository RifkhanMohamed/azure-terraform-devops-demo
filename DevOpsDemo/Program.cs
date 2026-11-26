var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => new
{
    Application = "DevOps Demo",
    Message = "Application is running successfully",
    Version = "1.0.0",
    Environment = app.Environment.EnvironmentName
});

app.MapGet("/health", () => Results.Ok(new
{
    Status = "Healthy",
    Timestamp = DateTime.UtcNow
}));

app.Run();