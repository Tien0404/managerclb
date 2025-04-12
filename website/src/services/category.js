import apiClient from "../utils/apiClient";

// Hàm lấy danh sách các danh mục
export const getCategories = async () => {
  try {
    const response = await apiClient.get("/categories");
    return response.data;
  } catch (error) {
    throw new Error("Lỗi khi lấy danh sách danh mục: " + error.message);
  }
};

// Hàm lấy chi tiết danh mục theo ID
export const getCategoryById = async (id) => {
  try {
    const response = await apiClient.get(`/categories/${id}`);
    return response.data;
  } catch (error) {
    throw new Error("Lỗi khi lấy chi tiết danh mục: " + error.message);
  }
};
