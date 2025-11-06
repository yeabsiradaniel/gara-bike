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

const getDashboardStats = () => {
  return axios.get(`${API_URL}/dashboard`, { headers: getAuthHeader() });
};

const adminService = {
  getDashboardStats,
};

export default adminService;
