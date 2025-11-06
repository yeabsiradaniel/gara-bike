import React, { useEffect, useState } from 'react';
import { Grid, Paper, Typography, Box, useTheme } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import adminService from '../services/adminService';
import PeopleIcon from '@mui/icons-material/People';
import ElectricBikeIcon from '@mui/icons-material/ElectricBike';
import SyncAltIcon from '@mui/icons-material/SyncAlt';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';

const StatCard = ({ title, value, icon }) => {
  const theme = useTheme();
  return (
    <Paper 
      elevation={3} 
      sx={{
        p: 3, // Increased padding for better spacing
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        height: '100%'
      }}
    >
      <Box>
        <Typography variant="h6" color="text.secondary" noWrap> {/* noWrap handles overflow */}
          {title}
        </Typography>
        <Typography variant="h4" sx={{ wordBreak: 'break-word' }}>
          {value}
        </Typography>
      </Box>
      <Box sx={{ color: theme.palette.primary.main }}>
        {React.cloneElement(icon, { sx: { fontSize: 40 } })}
      </Box>
    </Paper>
  );
};

const DashboardPage = () => {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    adminService.getDashboardStats()
      .then(response => {
        setStats(response.data);
      })
      .catch(error => {
        console.error("Failed to fetch dashboard stats:", error);
      });
  }, []);

  const chartData = [
    {
      name: 'Overview',
      Users: stats?.totalUsers,
      Bikes: stats?.totalBikes,
      Rides: stats?.activeRides,
    },
  ];

  return (
    <Box sx={{ flexGrow: 1 }}>
      <Typography variant="h4" sx={{ mb: 4 }}>Admin Dashboard</Typography>
      {stats ? (
        <Grid container spacing={3}>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard title="Total Users" value={stats.totalUsers} icon={<PeopleIcon />} />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard title="Total Bikes" value={stats.totalBikes} icon={<ElectricBikeIcon />} />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard title="Active Rides" value={stats.activeRides} icon={<SyncAltIcon />} />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <StatCard title="Total Revenue" value={`$${stats.totalRevenue.toFixed(2)}`} icon={<AttachMoneyIcon />} />
          </Grid>
          <Grid item xs={12}>
            <Paper elevation={3} sx={{ p: 2, height: { xs: 300, sm: 400 } }}>
              <Typography variant="h6" gutterBottom>Summary</Typography>
              <ResponsiveContainer width="100%" height="90%">
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" strokeOpacity={0.2} />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip contentStyle={{ backgroundColor: '#333' }} />
                  <Legend />
                  <Bar dataKey="Users" fill="#00bcd4" />
                  <Bar dataKey="Bikes" fill="#82ca9d" />
                  <Bar dataKey="Rides" fill="#ffc658" />
                </BarChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>
        </Grid>
      ) : (
        <Typography>Loading stats...</Typography>
      )}
    </Box>
  );
};

export default DashboardPage;