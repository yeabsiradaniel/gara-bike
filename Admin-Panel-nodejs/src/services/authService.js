import axios from 'axios';

const API_URL = 'http://localhost:3000/api'; // Your Node.js backend API base URL

const login = async (email, password) => {
  const response = await axios.post(`${API_URL}/login`, { email, password });
  if (response.data.token) {
    localStorage.setItem('user', JSON.stringify(response.data));
  } else {
    throw new Error('Login failed: No token received');
  }
  return response.data;
};

const logout = () => {
  localStorage.clear();
};

const getCurrentUser = () => {
  return JSON.parse(localStorage.getItem('user'));
};

const authService = {
  login,
  logout,
  getCurrentUser,
};

export default authService;
