import axios from "axios";

const base = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:5291";
const api = axios.create({ baseURL: `${base}/api` });

// Only install interceptor on client side
if (typeof window !== "undefined") {
    api.interceptors.request.use(
        (config) => {
            const token = localStorage.getItem("token");
            if (token && config.headers)
                config.headers.Authorization = `Bearer ${token}`;
            return config;
        },
        (error) => Promise.reject(error)
    );
}

export default api;
