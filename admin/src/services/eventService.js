import axios from 'axios';

const API_URL = 'http://localhost:8000/api/events';

export const getEvents = async () => {
  const response = await axios.get(API_URL);
  return response.data;
};

export const getEvent = async (id) => {
  const response = await axios.get(`${API_URL}/${id}`);
  return response.data;
};

export const createEvent = async (eventData) => {
  const response = await axios.post(API_URL, eventData);
  return response.data;
};

export const updateEvent = async (id, eventData) => {
  const response = await axios.patch(`${API_URL}/${id}`, eventData);
  return response.data;
};

export const deleteEvent = async (id) => {
  const response = await axios.delete(`${API_URL}/${id}`);
  return response.data;
};