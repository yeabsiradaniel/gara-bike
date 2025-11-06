import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import authService from '../services/authService';
import MainLayout from './MainLayout';

const ProtectedRoute = () => {
  const user = authService.getCurrentUser();
  console.log('ProtectedRoute user:', user);

  if (!user || !user.user.isAdmin) {
    return <Navigate to="/login" />;
  }

  return (
    <MainLayout>
      <Outlet />
    </MainLayout>
  );
};

export default ProtectedRoute;
