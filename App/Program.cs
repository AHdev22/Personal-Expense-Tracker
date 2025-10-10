using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using App.Services;

var builder = WebApplication.CreateBuilder(args);

// ----------------------------------------------------
// 🔹 Add services to the container
// ----------------------------------------------------
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAuthorization();
builder.Services.AddControllers();

// ----------------------------------------------------
// 🔹 Configure JWT authentication
// ----------------------------------------------------
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.ASCII.GetBytes(jwtSettings["Key"] ?? throw new Exception("JWT Key is missing"));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
        Encoding.UTF8.GetBytes(jwtSettings["Key"] ?? throw new Exception("JWT Key is missing"))
    )
    };
});

// ----------------------------------------------------
// 🔹 Configure MySQL database connection
// ----------------------------------------------------
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<App.Data.AppContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(builder.Configuration.GetConnectionString("DefaultConnection"))
    ));

builder.Services.AddDbContext<App.Data.AppContext>();

// ----------------------------------------------------
// 🔹 Register application services
// ----------------------------------------------------
builder.Services.AddScoped<TokenService>();

// ----------------------------------------------------
// 🔹 Build the app
// ----------------------------------------------------
var app = builder.Build();

// ----------------------------------------------------
// 🔹 Middleware pipeline
// ----------------------------------------------------
app.UseAuthentication();
app.UseAuthorization();
app.UseHttpsRedirection();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ----------------------------------------------------
// 🔹 Map controllers
app.MapControllers();

// ----------------------------------------------------
// 🔹 Run the app
// ----------------------------------------------------
app.Run();


