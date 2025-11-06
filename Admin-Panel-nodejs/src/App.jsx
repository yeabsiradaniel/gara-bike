import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import darkTheme from './theme/theme';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ProtectedRoute from './components/ProtectedRoute';
import UsersPage from './pages/UsersPage';
import BikesPage from './pages/BikesPage';
import ParkingZonesPage from './pages/ParkingZonesPage';

import CorporateAccountsPage from './pages/CorporateAccountsPage';
import RidesPage from './pages/RidesPage';
import SupportTicketsPage from './pages/SupportTicketsPage';
import BikeReportsPage from './pages/BikeReportsPage';
import UserPassesPage from './pages/UserPassesPage';
import TransactionsPage from './pages/TransactionsPage';
import WalletsPage from './pages/WalletsPage';

function App() {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <Router>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route element={<ProtectedRoute />}>
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/bikes" element={<BikesPage />} />
            <Route path="/parking-zones" element={<ParkingZonesPage />} />
            <Route path="/corporate-accounts" element={<CorporateAccountsPage />} />
            <Route path="/rides" element={<RidesPage />} />
            <Route path="/support-tickets" element={<SupportTicketsPage />} />
            <Route path="/bike-reports" element={<BikeReportsPage />} />
            <Route path="/user-passes" element={<UserPassesPage />} />
            <Route path="/transactions" element={<TransactionsPage />} />
            <Route path="/wallets" element={<WalletsPage />} />
          </Route>
          <Route path="*" element={<Navigate to="/dashboard" />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;
