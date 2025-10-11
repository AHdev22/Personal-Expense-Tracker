"use client";
import { AxiosError } from "axios";
import { useForm } from "react-hook-form";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import { useState } from "react";

type Form = { email: string; password: string };

export default function LoginPage() {
    const { register, handleSubmit } = useForm<Form>();
    const [err, setErr] = useState("");
    const router = useRouter();

    const onSubmit = async (data: Form) => {
        try {
            const res = await api.post("/auth/login", data);

            // Save token in localStorage
            localStorage.setItem("token", res.data.token);

            // Navigate to homepage
            router.push("/");
        } catch (error) {
            if (error instanceof AxiosError) {
                // Error from Axios request
                setErr(error.response?.data || "Invalid credentials");
            } else {
                // Unexpected error
                setErr("Invalid credentials");
            }
        }
    };

    return (
        <div className="flex items-center justify-center h-screen bg-gray-100">
            <form
                onSubmit={handleSubmit(onSubmit)}
                className="w-80 p-6 bg-white rounded shadow"
            >
                <h2 className="text-center mb-4 text-lg font-medium">Login</h2>
                {err && <p className="text-red-600 text-sm mb-2">{err}</p>}
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
                    Login
                </button>
            </form>
        </div>
    );
}
