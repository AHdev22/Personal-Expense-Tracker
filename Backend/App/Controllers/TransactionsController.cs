using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using App.Data;
using App.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Linq.Expressions;

namespace App.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TransactionsController : ControllerBase
    {
        private readonly App.Data.AppContext _context;

        public TransactionsController(App.Data.AppContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            var id = User.FindFirstValue(ClaimTypes.NameIdentifier) ??
                    User.FindFirstValue(JwtRegisteredClaimNames.Sub);
            return int.Parse(id ?? throw new Exception(Unauthorized().ToString()));
        }

        // 🔹 Get all transactions for the logged-in user
        [HttpGet]
        public async Task<IActionResult> GetMyTransactions()
        {
            var userId = GetUserId();
            var list = await _context.Transactions
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.Date)
                .ToListAsync();

            return Ok(list);
        }

        // 🔹 Add new transaction
        [HttpPost]
        public async Task<IActionResult> AddTransaction([FromBody] Transactions transaction)
        {
            var userId = GetUserId();
            transaction.UserId = userId;
            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();

            return Ok(transaction);
        }
        // 🔹 Get single transaction by ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTransactionById(int id)
        {
            var userId = GetUserId();
            var transaction = await _context.Transactions
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

            if (transaction == null)
                return NotFound(new { message = "Transaction not found" });

            return Ok(transaction);
        }


        // 🔹 Update transaction
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTransaction(int id, [FromBody] Transactions updated)
        {
            var userId = GetUserId();
            var transaction = await _context.Transactions.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            if (transaction == null) return NotFound();

            transaction.Title = updated.Title;
            transaction.Amount = updated.Amount;
            transaction.Type = updated.Type;
            transaction.Date = updated.Date;

            await _context.SaveChangesAsync();
            return Ok(transaction);
        }

        // 🔹 Delete transaction
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTransaction(int id)
        {
            var userId = GetUserId();
            var transaction = await _context.Transactions.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            if (transaction == null) return NotFound();

            _context.Transactions.Remove(transaction);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Transaction deleted successfully" });
        }

        // 🔹 Get summary totals (Income, Expense, Balance)
        [HttpGet("summary")]
        public async Task<IActionResult> GetSummary()
        {
            var userId = GetUserId();

            var income = await _context.Transactions
                .Where(t => t.UserId == userId && t.Type == "Income")
                .SumAsync(t => (decimal?)t.Amount) ?? 0;

            var expense = await _context.Transactions
                .Where(t => t.UserId == userId && t.Type == "Expense")
                .SumAsync(t => (decimal?)t.Amount) ?? 0;

            var balance = income - expense;

            return Ok(new
            {
                Income = income,
                Expense = expense,
                Balance = balance
            });
        }

        // 🔹 Filter by type and date range
        [HttpGet("filter")]
        public async Task<IActionResult> FilterTransactions(string? type, DateTime? from, DateTime? to)
        {
            var userId = GetUserId();

            var query = _context.Transactions.Where(t => t.UserId == userId);

            if (!string.IsNullOrEmpty(type))
                query = query.Where(t => t.Type == type);

            if (from.HasValue)
                query = query.Where(t => t.Date >= from.Value);

            if (to.HasValue)
                query = query.Where(t => t.Date <= to.Value.Date.AddDays(1).AddTicks(-1));

            var results = await query.OrderByDescending(t => t.Date).ToListAsync();

            return Ok(results);
        }

    }
}
