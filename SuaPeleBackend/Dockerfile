# Estágio de Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copia o arquivo
COPY ["suapelebackend.csproj", "./"]
RUN dotnet restore "suapelebackend.csproj"

# Copia o restante e publica
COPY . .
RUN dotnet publish "suapelebackend.csproj" -c Release -o /app/publish

# Estágio de Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .

#  Porta e DLL
EXPOSE 8080
ENTRYPOINT ["dotnet", "suapelebackend.dll"]