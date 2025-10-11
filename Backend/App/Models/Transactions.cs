namespace App.Models
{
    public class Transactions
    {
        public int Id { get; set; }
        public decimal Amount { get; set; }
        public string Title { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public string Method { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;

        public string Type { get; set; } = string.Empty; // "Income" or "Expense"
        public int UserId { get; set; }
        public Users? Users { get; set; }
    }
}