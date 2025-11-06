import React from 'react';
import { Drawer, List, ListItem, ListItemIcon, ListItemText, Toolbar, Box } from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import ElectricBikeIcon from '@mui/icons-material/ElectricBike';
import LocalParkingIcon from '@mui/icons-material/LocalParking';
import DirectionsBikeIcon from '@mui/icons-material/DirectionsBike';
import BusinessIcon from '@mui/icons-material/Business';
import RouteIcon from '@mui/icons-material/Route';
import SupportAgentIcon from '@mui/icons-material/SupportAgent';
import ReportIcon from '@mui/icons-material/Report';
import CardMembershipIcon from '@mui/icons-material/CardMembership';
import ReceiptIcon from '@mui/icons-material/Receipt';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import LogoutIcon from '@mui/icons-material/Logout'; // New icon for Logout
import { Link, useNavigate } from 'react-router-dom';
import authService from '../services/authService';

const drawerWidth = 240;

const menuItems = [
  { text: 'Dashboard', icon: <DashboardIcon />, path: '/dashboard' },
  { text: 'Users', icon: <PeopleIcon />, path: '/users' },
  { text: 'Bikes', icon: <DirectionsBikeIcon />, path: '/bikes' },
  { text: 'Parking Zones', icon: <LocalParkingIcon />, path: '/parking-zones' },
  { text: 'Corporate Accounts', icon: <BusinessIcon />, path: '/corporate-accounts' },
  { text: 'Rides', icon: <RouteIcon />, path: '/rides' },
  { text: 'Support Tickets', icon: <SupportAgentIcon />, path: '/support-tickets' },
  { text: 'Bike Reports', icon: <ReportIcon />, path: '/bike-reports' },
  { text: 'User Passes', icon: <CardMembershipIcon />, path: '/user-passes' },
  { text: 'Transactions', icon: <ReceiptIcon />, path: '/transactions' },
  { text: 'Wallets', icon: <AccountBalanceWalletIcon />, path: '/wallets' },
];

const Sidebar = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    authService.logout();
    navigate('/login');
  };

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: { width: drawerWidth, boxSizing: 'border-box' },
      }}
    >
      <Toolbar />
      <List>
        {menuItems.map((item) => (
          <ListItem component={Link} to={item.path} key={item.text}>
            <ListItemIcon>{item.icon}</ListItemIcon>
            <ListItemText primary={item.text} />
          </ListItem>
        ))}
      </List>
      <Box sx={{ flexGrow: 1 }} />
      <List>
        <ListItem onClick={handleLogout}>
          <ListItemIcon><LogoutIcon /></ListItemIcon>
          <ListItemText primary="Logout" />
        </ListItem>
      </List>
    </Drawer>
  );
};

export default Sidebar;