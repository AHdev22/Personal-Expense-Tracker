"use client";

import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { AxiosError } from "axios";
import api from "@/lib/api";
import { useState } from "react";

type TransactionForm = {
    title: string;
    category: string;
    amount: number;
    type: "income" | "expense";
    date: string;
    method: string;
};

export default function AddTransaction() {
    const router = useRouter();
    const [serverError, setServerError] = useState("");
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        reset,
    } = useForm<TransactionForm>({
        defaultValues: {
            title: "",
            category: "",
            amount: 0,
            type: "income",
            date: "",
            method: "",
        },
    });

    const onSubmit = async (data: TransactionForm) => {
        setServerError("");

        try {
            await api.post("/Transactions", {
                title: data.title.trim(),
                category: data.category.trim(),
                amount: parseFloat(data.amount.toString()),
                type: data.type,
                date: data.date || new Date().toISOString(),
                method: data.method.trim(),
            });

            reset();
            router.push("/");
        } catch (error) {
            if (error instanceof AxiosError) {
                const message =
                    typeof error.response?.data === "string"
                        ? error.response.data
                        : error.response?.data?.message ||
                          "Failed to add transaction";
                setServerError(message);
            } else {
                setServerError("Unexpected error occurred. Please try again.");
            }
        }
    };

    return (
        <div className="flex min-h-full flex-col justify-center px-6 py-12 lg:px-8 bg-gray-900">
            <div className="sm:mx-auto sm:w-full sm:max-w-sm">
                <h2 className="mt-10 text-center text-2xl font-bold tracking-tight text-white">
                    Add New Transaction
                </h2>
            </div>

            <div className="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                    {/* Server Error */}
                    {serverError && (
                        <p className="text-red-500 text-sm text-center">
                            {serverError}
                        </p>
                    )}

                    {/* Title */}
                    <div>
                        <label
                            htmlFor="title"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Title
                        </label>
                        <div className="mt-2">
                            <input
                                id="title"
                                type="text"
                                {...register("title", {
                                    required: "Title is required",
                                    minLength: {
                                        value: 3,
                                        message:
                                            "Title must be at least 3 characters",
                                    },
                                })}
                                placeholder="e.g. Grocery Shopping"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm"
                            />
                            {errors.title && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.title.message}
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Category */}
                    <div>
                        <label
                            htmlFor="category"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Category
                        </label>
                        <div className="mt-2">
                            <input
                                id="category"
                                type="text"
                                {...register("category", {
                                    required: "Category is required",
                                })}
                                placeholder="e.g. Food, Rent, Salary"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm"
                            />
                            {errors.category && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.category.message}
                                </p>
                            )}
                        </div>
                    </div>
                    {/* Method */}
                    <div>
                        <label
                            htmlFor="method"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Method
                        </label>
                        <div className="mt-2">
                            <input
                                id="method"
                                type="text"
                                {...register("method", {
                                    required: "Method is required",
                                })}
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm"
                            />
                            {errors.method && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.method.message}
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Type */}
                    <div>
                        <label
                            htmlFor="type"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Type
                        </label>
                        <div className="mt-2">
                            <select
                                id="type"
                                {...register("type", { required: true })}
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 focus:outline-2 
                                focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm cursor-pointer"
                            >
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
                    </div>

                    {/* Amount */}
                    <div>
                        <label
                            htmlFor="amount"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Amount
                        </label>
                        <div className="mt-2">
                            <input
                                id="amount"
                                type="number"
                                step="0.01"
                                {...register("amount", {
                                    required: "Amount is required",
                                    min: {
                                        value: 0.01,
                                        message:
                                            "Amount must be greater than 0",
                                    },
                                })}
                                placeholder="e.g. 150.00"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm"
                            />
                            {errors.amount && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.amount.message}
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Date */}
                    <div>
                        <label
                            htmlFor="date"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Date
                        </label>
                        <div className="mt-2">
                            <input
                                id="date"
                                type="date"
                                {...register("date", {
                                    required: "Date is required",
                                })}
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 focus:outline-2 
                                focus:-outline-offset-2 focus:outline-indigo-500 sm:text-sm"
                            />
                            {errors.date && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.date.message}
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Submit */}
                    <div>
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="flex w-full justify-center rounded-md bg-indigo-500 px-3 py-1.5
                            text-sm font-semibold text-white hover:bg-indigo-400
                            focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-900 cursor-pointer disabled:opacity-60 disabled:cursor-not-allowed"
                        >
                            {isSubmitting ? "Adding..." : "Add Transaction"}
                        </button>
                    </div>
                </form>

                <button
                    onClick={() => router.push("/")}
                    className="mt-8 w-full text-indigo-400 text-sm font-semibold hover:text-indigo-300 text-center cursor-pointer"
                >
                    ← Back to Dashboard
                </button>
            </div>
        </div>
    );
}
