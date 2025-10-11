using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using App.Services;

var builder = WebApplication.CreateBuilder(args);

// ----------------------------------------------------
// 🔹 Add services to the container
// ----------------------------------------------------
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();

// ✅ Swagger configuration with JWT support
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "App", Version = "v1" });

    // 🔒 Add JWT Authorization to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter your JWT token in this format: Bearer {your token here}"
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

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("http://localhost:3000")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});



builder.Services.AddAuthorization();
builder.Services.AddControllers();

// ----------------------------------------------------
// 🔹 Configure JWT authentication
// ----------------------------------------------------
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSettings["Key"] ?? throw new Exception("JWT Key is missing"));

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

// ----------------------------------------------------
// 🔹 Configure MySQL database connection
// ----------------------------------------------------
builder.Services.AddDbContext<App.Data.AppContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(builder.Configuration.GetConnectionString("DefaultConnection"))
    ));

// ----------------------------------------------------
// 🔹 Register application services
// ----------------------------------------------------
builder.Services.AddScoped<TokenService>();

// ----------------------------------------------------
// 🔹 Build the app
// ----------------------------------------------------
var app = builder.Build();

// ----------------------------------------------------
// 🔹 Middleware pipeline (✅ correct order)
// ----------------------------------------------------
app.UseHttpsRedirection();
app.UseCors();
app.UseRouting();                // ✅ Add this before authentication

app.UseAuthentication();         // ✅ Must be before Authorization
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ✅ Map controllers inside routing
app.MapControllers();

// ----------------------------------------------------
// 🔹 Run the app
// ----------------------------------------------------
app.Run();
