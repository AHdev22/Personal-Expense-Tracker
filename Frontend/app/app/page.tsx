"use client";

import { useEffect, useState, useCallback } from "react";
import { AxiosError } from "axios";
import api from "@/lib/api";
import { useRouter } from "next/navigation";

type User = { name: string };
type Transaction = {
    id: number;
    title: string;
    category: string;
    amount: number;
    type: "income" | "expense";
    date: string;
};
type Summary = { income: number; expense: number; balance: number };

export default function Dashboard() {
    const router = useRouter();

    const [user, setUser] = useState<User | null>(null);
    const [summary, setSummary] = useState<Summary | null>(null);
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(true);

    const [type, setType] = useState("");
    const [from, setFrom] = useState("");
    const [to, setTo] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [deleteId, setDeleteId] = useState<number | null>(null);

    const handleError = useCallback((error: unknown) => {
        if (error instanceof AxiosError) {
            const message =
                typeof error.response?.data === "string"
                    ? error.response.data
                    : error.response?.data?.message || "Failed to load data.";
            setError(message);
        } else {
            setError("Unexpected error occurred. Please try again.");
        }
    }, []);

    const loadAllData = useCallback(async () => {
        setLoading(true);
        try {
            const [meRes, sumRes, trxRes] = await Promise.all([
                api.get("/Auth/me"),
                api.get("/Transactions/summary"),
                api.get("/Transactions"),
            ]);
            setUser(meRes.data);
            setSummary(sumRes.data);
            setTransactions(trxRes.data);
        } catch (error) {
            handleError(error);
        } finally {
            setLoading(false);
        }
    }, [handleError]);

    useEffect(() => {
        loadAllData();
    }, [loadAllData]);

    const handleFilter = async () => {
        setLoading(true);
        try {
            const res = await api.get("/Transactions/filter", {
                params: { type, from, to },
            });
            setTransactions(res.data);
        } catch (error) {
            handleError(error);
        } finally {
            setLoading(false);
        }
    };

    const handleAdd = () => router.push("/add-transaction");
    const handleEdit = (id: number) => router.push(`/edit-transaction/${id}`);

    const handleDelete = async () => {
        if (!deleteId) return;

        try {
            // Delete transaction from backend
            await api.delete(`/Transactions/${deleteId}`);

            // Update local state (remove deleted transaction)
            setTransactions((prev) => prev.filter((t) => t.id !== deleteId));

            // Optionally re-fetch data to ensure totals are up-to-date (recommended)
            await loadAllData?.();
        } catch (error) {
            handleError(error);
        } finally {
            // Close the modal and reset delete ID
            setShowModal(false);
            setDeleteId(null);
        }
    };

    const handleLogout = () => {
        localStorage.removeItem("token");
        window.location.href = "/login";
    };

    return (
        <div className="min-h-screen bg-gray-900 text-white flex flex-col">
            {/* Header */}
            <header className="flex justify-between items-center px-6 py-4 border-b border-white/10 bg-white/5 backdrop-blur-sm">
                <h1 className="text-xl font-bold text-indigo-400">
                    Expense Tracker
                </h1>
                <div className="flex items-center gap-4">
                    {user && (
                        <span className="text-gray-200 text-sm">
                            {user.name}
                        </span>
                    )}
                    <button
                        onClick={handleLogout}
                        className="bg-red-600 text-white px-3 py-1 rounded-md text-sm hover:bg-red-700 
                        focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600 cursor-pointer"
                    >
                        Logout
                    </button>
                </div>
            </header>

            <main className="flex-1 min-w-6xl  mx-auto p-6">
                {loading && (
                    <p className="text-center text-indigo-400 mt-6">
                        Loading...
                    </p>
                )}

                {!loading && error && (
                    <p className="text-red-500 text-center mt-6 font-medium">
                        {error}
                    </p>
                )}

                {!loading && !error && summary && (
                    <>
                        {/* Summary Cards */}
                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                            <div className="bg-white/5 p-5 rounded-lg border border-white/10 text-center">
                                <h2 className="text-gray-300 text-sm font-medium">
                                    Income
                                </h2>
                                <p className="text-green-400 text-2xl font-bold mt-1">
                                    ${summary.income.toFixed(2)}
                                </p>
                            </div>
                            <div className="bg-white/5 p-5 rounded-lg border border-white/10 text-center">
                                <h2 className="text-gray-300 text-sm font-medium">
                                    Expense
                                </h2>
                                <p className="text-red-400 text-2xl font-bold mt-1">
                                    ${summary.expense.toFixed(2)}
                                </p>
                            </div>
                            <div className="bg-white/5 p-5 rounded-lg border border-white/10 text-center">
                                <h2 className="text-gray-300 text-sm font-medium">
                                    Balance
                                </h2>
                                <p className="text-indigo-400 text-2xl font-bold mt-1">
                                    ${summary.balance.toFixed(2)}
                                </p>
                            </div>
                        </div>

                        {/* Filter Controls */}
                        <div className="bg-white/5 border border-white/10 rounded-lg p-4 mb-6 flex flex-wrap gap-4 items-end justify-around">
                            <div>
                                <label className="text-gray-300 text-sm mr-4">
                                    Type
                                </label>
                                <select
                                    value={type}
                                    onChange={(e) => setType(e.target.value)}
                                    className="w-40 bg-white/10 text-white border border-white/10 rounded-md px-3 py-2 text-sm focus:outline-2 focus:outline-indigo-500 cursor-pointer"
                                >
                                    <option
                                        value=""
                                        className="text-black cursor-pointer"
                                    >
                                        All
                                    </option>
                                    <option
                                        value="income"
                                        className="text-black cursor-pointer"
                                    >
                                        Income
                                    </option>
                                    <option
                                        value="expense"
                                        className="text-black cursor-pointer"
                                    >
                                        Expense
                                    </option>
                                </select>
                            </div>
                            <div>
                                <label className="text-gray-300 text-sm mr-4">
                                    From
                                </label>
                                <input
                                    type="date"
                                    value={from}
                                    onChange={(e) => setFrom(e.target.value)}
                                    className="bg-white/10 text-white border border-white/10 rounded-md px-3 py-2 text-sm focus:outline-2 focus:outline-indigo-500 cursor-pointer"
                                />
                            </div>
                            <div>
                                <label className="text-gray-300 text-sm mr-4">
                                    To
                                </label>
                                <input
                                    type="date"
                                    value={to}
                                    onChange={(e) => setTo(e.target.value)}
                                    className="bg-white/10 text-white border border-white/10 rounded-md px-3 py-2 text-sm focus:outline-2 focus:outline-indigo-500 cursor-pointer"
                                />
                            </div>
                            <button
                                onClick={handleFilter}
                                className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm hover:bg-indigo-500 
                                focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 cursor-pointer"
                            >
                                Filter
                            </button>
                            <button
                                onClick={handleAdd}
                                className="bg-green-600 text-white px-4 py-2 rounded-md text-sm hover:bg-green-500 
                                focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green-600 cursor-pointer"
                            >
                                Add Transaction
                            </button>
                        </div>

                        {/* Transactions Table */}
                        <div className="overflow-x-auto bg-white/5 border border-white/10 rounded-lg">
                            <table className="w-full text-left border-collapse">
                                <thead>
                                    <tr className="bg-white/10 border-b border-white/10 text-gray-300 text-sm">
                                        <th className="p-3">#</th>
                                        <th className="p-3">Title</th>
                                        <th className="p-3">Category</th>
                                        <th className="p-3">Type</th>
                                        <th className="p-3">Amount</th>
                                        <th className="p-3">Date</th>
                                        <th className="p-3 text-center">
                                            Actions
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {transactions.length === 0 ? (
                                        <tr>
                                            <td
                                                colSpan={7}
                                                className="text-center py-6 text-gray-400"
                                            >
                                                No transactions found.
                                            </td>
                                        </tr>
                                    ) : (
                                        transactions.map((t, i) => (
                                            <tr
                                                key={t.id}
                                                className="border-b border-white/5 hover:bg-white/5 transition"
                                            >
                                                <td className="p-3 text-gray-300">
                                                    {i + 1}
                                                </td>
                                                <td className="p-3">
                                                    {t.title}
                                                </td>
                                                <td className="p-3 text-gray-400">
                                                    {t.category}
                                                </td>
                                                <td
                                                    className={`p-3 font-medium ${
                                                        t.type === "income"
                                                            ? "text-green-400"
                                                            : "text-red-400"
                                                    }`}
                                                >
                                                    {t.type}
                                                </td>
                                                <td className="p-3 text-gray-200">
                                                    ${t.amount.toFixed(2)}
                                                </td>
                                                <td className="p-3 text-gray-300">
                                                    {new Date(
                                                        t.date
                                                    ).toLocaleDateString()}
                                                </td>
                                                <td className="p-3 text-center space-x-2">
                                                    <button
                                                        onClick={() =>
                                                            handleEdit(t.id)
                                                        }
                                                        className="bg-indigo-600 text-white px-3 py-1 rounded text-sm hover:bg-indigo-500 cursor-pointer mr-3"
                                                    >
                                                        Edit
                                                    </button>
                                                    <button
                                                        onClick={() => {
                                                            setDeleteId(t.id);
                                                            setShowModal(true);
                                                        }}
                                                        className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-500 cursor-pointer"
                                                    >
                                                        Delete
                                                    </button>
                                                </td>
                                            </tr>
                                        ))
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </>
                )}
                {showModal && (
                    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50">
                        <div className="bg-gray-800 border border-white/10 rounded-lg p-6 w-96 text-center shadow-lg ">
                            <h2 className="text-lg font-semibold text-white mb-4">
                                Delete Transaction?
                            </h2>
                            <p className="text-gray-400 text-sm mb-6">
                                Are you sure you want to delete this
                            </p>
                            <div className="flex justify-center gap-4">
                                <button
                                    onClick={handleDelete}
                                    className="bg-red-600 hover:bg-red-700 px-4 py-2 rounded text-white text-sm cursor-pointer"
                                >
                                    Delete
                                </button>
                                <button
                                    onClick={() => {
                                        setShowModal(false);
                                        setDeleteId(null);
                                    }}
                                    className="bg-gray-600 hover:bg-gray-500 px-4 py-2 rounded text-white text-sm cursor-pointer"
                                >
                                    Cancel
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}
