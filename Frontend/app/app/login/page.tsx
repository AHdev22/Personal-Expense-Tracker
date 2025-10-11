"use client";
import { AxiosError } from "axios";
import { useForm } from "react-hook-form";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";

type Form = { email: string; password: string };

export default function LoginPage() {
    const {
        register,
        handleSubmit,
        formState: { errors },
    } = useForm<Form>();
    const [serverError, setServerError] = useState("");
    const router = useRouter();

    const onSubmit = async (data: Form) => {
        setServerError("");
        try {
            const res = await api.post("/auth/login", data);
            localStorage.setItem("token", res.data.token);
            router.push("/");
        } catch (error) {
            if (error instanceof AxiosError) {
                const message =
                    typeof error.response?.data === "string"
                        ? error.response.data
                        : error.response?.data?.message ||
                          "Invalid credentials";
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
                    Sign in to your account
                </h2>
            </div>

            <div className="mt-4 sm:mx-auto sm:w-full sm:max-w-sm">
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                    {/* Server Error */}
                    {serverError && (
                        <p className="text-red-500 text-sm text-center mb-0.5">
                            {serverError}
                        </p>
                    )}

                    {/* Email Field */}
                    <div>
                        <label
                            htmlFor="email"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Email address
                        </label>
                        <div className="mt-2">
                            <input
                                id="email"
                                type="email"
                                autoComplete="email"
                                {...register("email", {
                                    required: "Email is required",
                                    pattern: {
                                        value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                                        message: "Invalid email format",
                                    },
                                })}
                                placeholder="you@example.com"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white placeholder-gray-500 outline-none ring-1 ring-inset ring-white/10 focus:ring-2 focus:ring-inset focus:ring-indigo-500 sm:text-sm"
                            />
                        </div>
                        {errors.email && (
                            <p className="text-red-500 text-xs mt-1">
                                {errors.email.message}
                            </p>
                        )}
                    </div>

                    {/* Password Field */}
                    <div>
                        <div className="flex items-center justify-between">
                            <label
                                htmlFor="password"
                                className="block text-sm font-medium text-gray-100"
                            >
                                Password
                            </label>
                        </div>
                        <div className="mt-2">
                            <input
                                id="password"
                                type="password"
                                autoComplete="current-password"
                                {...register("password", {
                                    required: "Password is required",
                                    minLength: {
                                        value: 8,
                                        message:
                                            "Password must be at least 8 characters",
                                    },
                                })}
                                placeholder="********"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-base text-white placeholder-gray-500 outline-none ring-1 ring-inset ring-white/10 focus:ring-2 focus:ring-inset focus:ring-indigo-500 sm:text-sm"
                            />
                        </div>
                        {errors.password && (
                            <p className="text-red-500 text-xs mt-1">
                                {errors.password.message}
                            </p>
                        )}
                    </div>

                    {/* Submit Button */}
                    <div>
                        <div className="text-sm mb-2">
                            <Link
                                href="#"
                                className="font-semibold text-indigo-400 hover:text-indigo-300"
                            >
                                Forgot password?
                            </Link>
                        </div>
                        <button
                            type="submit"
                            className="flex w-full justify-center rounded-md bg-indigo-500 px-3 py-1.5 text-sm font-semibold text-white hover:bg-indigo-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500 cursor-pointer"
                        >
                            Sign in
                        </button>
                    </div>
                </form>

                <p className="mt-10 text-center text-sm text-gray-400">
                    Not a member?{" "}
                    <Link
                        href="/register"
                        className="font-semibold text-indigo-400 hover:text-indigo-300"
                    >
                        Create a new account
                    </Link>
                </p>
            </div>
        </div>
    );
}
