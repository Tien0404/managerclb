import axios from 'axios';

const API_URL = 'http://localhost:8000/api/clubs';

export const getClubs = async () => {
  const response = await axios.get(API_URL);
  return response.data;
};

export const getClub = async (id) => {
  const response = await axios.get(`${API_URL}/${id}`);
  return response.data;
};

export const createClub = async (clubData) => {
  const response = await axios.post(API_URL, clubData);
  return response.data;
};

export const updateClub = async (id, clubData) => {
  const response = await axios.patch(`${API_URL}/${id}`, clubData);
  return response.data;
};

export const deleteClub = async (id) => {
  const response = await axios.delete(`${API_URL}/${id}`);
  return response.data;
};