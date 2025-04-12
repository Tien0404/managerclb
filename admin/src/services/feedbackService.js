import axios from 'axios';

const API_URL = 'http://localhost:8000/api/feedbacks';

export const getFeedbacks = async () => {
  const response = await axios.get(API_URL);
  return response.data;
};

export const getFeedback = async (id) => {
  const response = await axios.get(`${API_URL}/${id}`);
  return response.data;
};

export const createFeedback = async (feedbackData) => {
  const response = await axios.post(API_URL, feedbackData);
  return response.data;
};

export const updateFeedback = async (id, feedbackData) => {
  const response = await axios.patch(`${API_URL}/${id}`, feedbackData);
  return response.data;
};

export const deleteFeedback = async (id) => {
  const response = await axios.delete(`${API_URL}/${id}`);
  return response.data;
};