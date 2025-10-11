"use client";
import { AxiosError } from "axios";
import { useForm } from "react-hook-form";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";

type Form = { name: string; email: string; password: string };

export default function RegisterPage() {
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
            await api.post("/auth/register", data);
            router.push("/login");
        } catch (error) {
            if (error instanceof AxiosError) {
                const message =
                    typeof error.response?.data === "string"
                        ? error.response.data
                        : error.response?.data?.message ||
                          "Registration failed";
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
                    Create your account
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

                    {/* Name */}
                    <div>
                        <label
                            htmlFor="name"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Name
                        </label>
                        <div className="mt-2">
                            <input
                                id="name"
                                type="text"
                                {...register("name", {
                                    required: "Name is required",
                                    minLength: {
                                        value: 3,
                                        message:
                                            "Name must be at least 3 characters",
                                    },
                                })}
                                placeholder="Your Name"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 
                                sm:text-sm"
                            />
                            {errors.name && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.name.message}
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Email */}
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
                                {...register("email", {
                                    required: "Email is required",
                                    pattern: {
                                        value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                                        message: "Invalid email format",
                                    },
                                })}
                                placeholder="you@example.com"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 
                                sm:text-sm"
                            />
                            {errors.email && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.email.message}
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Password */}
                    <div>
                        <label
                            htmlFor="password"
                            className="block text-sm font-medium text-gray-100"
                        >
                            Password
                        </label>
                        <div className="mt-2">
                            <input
                                id="password"
                                type="password"
                                {...register("password", {
                                    required: "Password is required",
                                    minLength: {
                                        value: 8,
                                        message:
                                            "Password must be at least 8 characters",
                                    },
                                })}
                                placeholder="********"
                                className="block w-full rounded-md bg-white/5 px-3 py-1.5 text-white 
                                outline-1 -outline-offset-1 outline-white/10 placeholder:text-gray-500 
                                focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-500 
                                sm:text-sm"
                            />
                            {errors.password && (
                                <p className="text-red-500 text-xs mt-1">
                                    {errors.password.message}
                                </p>
                            )}
                        </div>
                    </div>

                    <div>
                        <button
                            type="submit"
                            className="flex w-full justify-center rounded-md bg-indigo-500 px-3 py-1.5
                            text-sm font-semibold text-white hover:bg-indigo-400
                            focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-900 cursor-pointer"
                        >
                            Sign up
                        </button>
                    </div>
                </form>

                <p className="mt-10 text-center text-sm text-gray-400">
                    Already have an account?{" "}
                    <Link
                        href="/login"
                        className="font-semibold text-indigo-400 hover:text-indigo-300"
                    >
                        Sign in here
                    </Link>
                </p>
            </div>
        </div>
    );
}
