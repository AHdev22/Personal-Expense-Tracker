using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using App.Services;

var builder = WebApplication.CreateBuilder(args);

// ============================================================================
// KESTREL SETTINGS — allow API to be reached from network / Flutter / web
// ============================================================================
builder.WebHost.ConfigureKestrel(options =>
{
    // This makes the API reachable on http://<YourLocalIP>:5291
    options.ListenAnyIP(5291);
});

// ============================================================================
// SERVICES
// ============================================================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// ----------------------------------------------------------------------------
// Swagger (API Documentation + JWT Support)
// ----------------------------------------------------------------------------
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "App API", Version = "v1" });

    // JWT input field in Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter JWT token: Bearer {your token}"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// ============================================================================
// CORS SETTINGS — This was the main issue causing "Failed to fetch"
// ============================================================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()        // Allow all domains
            .AllowAnyMethod()        // GET, POST, PUT, DELETE, OPTIONS
            .AllowAnyHeader()        // Allow all headers
            .WithExposedHeaders("*"); // Let browser read custom headers
    });
});

// ============================================================================
// JWT Authentication
// ============================================================================
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSettings["Key"] ?? throw new Exception("JWT Key missing"));

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
        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
});

builder.Services.AddAuthorization();

// ============================================================================
// DATABASE
// ============================================================================
builder.Services.AddDbContext<App.Data.AppContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(builder.Configuration.GetConnectionString("DefaultConnection"))
    ));

// ============================================================================
// APPLICATION SERVICES
// ============================================================================
builder.Services.AddScoped<TokenService>();

// ============================================================================
// BUILD APP
// ============================================================================
var app = builder.Build();

// ============================================================================
// MIDDLEWARE — ORDER IS VERY IMPORTANT FOR CORS TO WORK
// ============================================================================

// -------------------------------
// 1️⃣ Routing must come first
// -------------------------------
app.UseRouting();

// -------------------------------
// 2️⃣ CORS MUST be between UseRouting and UseAuthentication
//    This fixes the preflight (OPTIONS) failure
// -------------------------------
app.UseCors("AllowAll");

// -------------------------------
// 3️⃣ Authentication + Authorization
// -------------------------------
app.UseAuthentication();
app.UseAuthorization();

// -------------------------------
// 4️⃣ DO NOT force HTTPS during testing
//    This causes Flutter/web to fail when backend is HTTP
// -------------------------------
// app.UseHttpsRedirection();

// -------------------------------
// Swagger (enabled in Development)
// -------------------------------
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "App API v1");
    });
}

// -------------------------------
// 5️⃣ Map Controllers (final step)
// -------------------------------
app.MapControllers();

// ============================================================================
// RUN
// ============================================================================
app.Run();
