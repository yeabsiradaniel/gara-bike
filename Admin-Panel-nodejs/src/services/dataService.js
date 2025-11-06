import axios from 'axios';
import authService from './authService';

const API_URL = 'http://localhost:3000/api/admin';

const getAuthHeader = () => {
  const user = authService.getCurrentUser();
  if (user && user.token) {
    return { Authorization: 'Bearer ' + user.token };
  }
  return {};
};

// Generic function to get all items of a certain type
const getAll = (resource) => {
  return axios.get(`${API_URL}/${resource}`, { headers: getAuthHeader() });
};

// Generic function to update an item
const update = (resource, id, data) => {
  return axios.put(`${API_URL}/${resource}/${id}`, data, { headers: getAuthHeader() });
};

// Generic function to create a new item
const create = (resource, data) => {
  return axios.post(`${API_URL}/${resource}`, data, { headers: getAuthHeader() });
};

// Generic function to delete an item
const remove = (resource, id) => {
  return axios.delete(`${API_URL}/${resource}/${id}`, { headers: getAuthHeader() });
};

const dataService = {
  getAll,
  update,
  create,
  remove,
};

export default dataService;
