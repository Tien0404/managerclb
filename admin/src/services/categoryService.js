import axios from 'axios';

const API_URL = 'http://localhost:8000/api/categories';

export const getCategories = async () => {
  const response = await axios.get(API_URL);
  return response.data;
};

export const getCategory = async (id) => {
  const response = await axios.get(`${API_URL}/${id}`);
  return response.data;
};

export const createCategory = async (categoryData) => {
  const response = await axios.post(API_URL, categoryData);
  return response.data;
};

export const updateCategory = async (id, categoryData) => {
  const response = await axios.patch(`${API_URL}/${id}`, categoryData);
  return response.data;
};

export const deleteCategory = async (id) => {
  const response = await axios.delete(`${API_URL}/${id}`);
  return response.data;
};