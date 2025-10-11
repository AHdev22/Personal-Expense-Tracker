using Microsoft.AspNetCore.Mvc;
using App.Data;
using App.Models;
using App.DTOs;
using App.Services;
using BCrypt.Net;
using Microsoft.EntityFrameworkCore;
using APP.DTOs;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;


namespace App.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly App.Data.AppContext _context;
        private readonly TokenService _tokenService;

        public AuthController(App.Data.AppContext context, TokenService tokenService)
        {
            _context = context;
            _tokenService = tokenService;
        }

        // ================== REGISTER ==================
        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            try
            {
                // ✅ 1. Check for existing email
                if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                    return BadRequest(new { message = "Email already registered." });

                // ✅ 2. Create new user
                var user = new Users
                {
                    Name = request.Name,
                    Email = request.Email,
                    Password = BCrypt.Net.BCrypt.HashPassword(request.Password) // use PasswordHash now
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                // ✅ 3. Generate JWT token
                var token = _tokenService.GenerateToken(user);

                // ✅ 4. Return success
                return Ok(new AuthResponse
                {
                    Token = token,
                    Name = user.Name,
                    Email = user.Email
                });
            }
            catch (DbUpdateException dbEx)
            {
                Console.WriteLine($"[DB ERROR] {dbEx}");
                return StatusCode(500, new { message = "Database operation failed. Please try again later." });
            }
            catch (InvalidOperationException invEx)
            {
                Console.WriteLine($"[INVALID OPERATION] {invEx}");
                return StatusCode(500, new { message = "An internal operation failed. Contact support." });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UNEXPECTED ERROR] {ex}");
                return StatusCode(500, new { message = "Unexpected server error. Please try again later." });
            }
        }

        // ================== LOGIN ==================
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            try
            {
                // ✅ 1. Validate required fields (just sanity check)
                if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                    return BadRequest(new { message = "Email and password are required." });

                // ✅ 2. Find user
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
                if (user == null)
                    return Unauthorized(new { message = "Invalid email or password." });

                // ✅ 3. Validate password
                bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.Password);
                if (!isPasswordValid)
                    return Unauthorized(new { message = "Invalid email or password." });

                // ✅ 4. Generate token
                var token = _tokenService.GenerateToken(user);

                return Ok(new AuthResponse
                {
                    Token = token,
                    Name = user.Name,
                    Email = user.Email
                });
            }
            catch (DbUpdateException dbEx)
            {
                Console.WriteLine($"[DB ERROR] {dbEx}");
                return StatusCode(500, new { message = "Database operation failed. Please try again later." });
            }
            catch (InvalidOperationException invEx)
            {
                Console.WriteLine($"[INVALID OPERATION] {invEx}");
                return StatusCode(500, new { message = "An internal operation failed. Contact support." });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UNEXPECTED ERROR] {ex}");
                return StatusCode(500, new { message = "Unexpected server error. Please try again later." });
            }
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
                        ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);

            if (userId == null) return Unauthorized();

            var user = await _context.Users.FindAsync(int.Parse(userId));
            if (user == null) return NotFound();

            return Ok(new
            {
                user.Id,
                user.Name,
                user.Email,
                user.CreatedAt
            });
        }
    }
}
