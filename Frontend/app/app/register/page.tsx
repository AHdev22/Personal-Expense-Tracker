"use client";
import { AxiosError } from "axios";
import { useForm } from "react-hook-form";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import { useState } from "react";

type Form = { name: string; email: string; password: string };

export default function RegisterPage() {
    const { register, handleSubmit } = useForm<Form>();
    const [err, setErr] = useState("");
    const router = useRouter();

    const onSubmit = async (data: Form) => {
        try {
            await api.post("/auth/register", data);
            router.push("/login");
        } catch (error) {
            // Type guard to ensure error is AxiosError
            if (error instanceof AxiosError) {
                setErr(error.response?.data || "Registration failed");
            } else {
                setErr("Registration failed");
            }
        }
    };

    return (
        <div className="flex items-center justify-center h-screen bg-gray-100">
            <form
                onSubmit={handleSubmit(onSubmit)}
                className="w-80 p-6 bg-white rounded shadow"
            >
                <h2 className="text-center mb-4 text-lg font-medium">
                    Register
                </h2>
                {err && <p className="text-red-600 text-sm mb-2">{err}</p>}
                <input
                    {...register("name")}
                    type="text"
                    placeholder="Name"
                    className="w-full mb-3 p-2 border rounded"
                    required
                />
                <input
                    {...register("email")}
                    type="email"
                    placeholder="Email"
                    className="w-full mb-3 p-2 border rounded"
                    required
                />
                <input
                    {...register("password")}
                    type="password"
                    placeholder="Password"
                    className="w-full mb-4 p-2 border rounded"
                    required
                />
                <button className="w-full p-2 bg-blue-600 text-white rounded">
                    Register
                </button>
            </form>
        </div>
    );
}
