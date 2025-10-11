# ---- Build Stage ----
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy csproj and restore
COPY *.sln .
COPY ["App.Api/App.Api.csproj", "App.Api/"]
RUN dotnet restore "App.Api/App.Api.csproj"

# Copy all and build
COPY . .
WORKDIR "/app/App.Api"
RUN dotnet publish -c Release -o /out

# ---- Runtime Stage ----
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "App.Api.dll"]
