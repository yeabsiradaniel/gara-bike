import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';

const RidesPage = () => {
  const [rides, setRides] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [rideToDelete, setRideToDelete] = useState(null);

  const fetchRides = () => {
    setLoading(true);
    dataService.getAll('rides')
      .then(response => {
        setRides(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch rides:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchRides();
  }, []);

  const handleDeleteClick = (id) => {
    setRideToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('rides', rideToDelete);
      fetchRides();
      setDeleteDialogOpen(false);
      setRideToDelete(null);
    } catch (error) {
      console.error("Failed to delete ride:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'Ride ID', width: 220 },
    { field: 'user', headerName: 'User Email', width: 220, valueGetter: (params) => params.row.user.email },
    { field: 'bike', headerName: 'Bike QR Code', width: 150, valueGetter: (params) => params.row.bike.qr_code },
    { field: 'start_time', headerName: 'Start Time', type: 'dateTime', width: 180, valueGetter: (value) => new Date(value) },
    { field: 'end_time', headerName: 'End Time', type: 'dateTime', width: 180, valueGetter: (value) => value ? new Date(value) : null },
    { field: 'cost', headerName: 'Cost', type: 'number', width: 100 },
    { field: 'distance_meters', headerName: 'Distance (m)', type: 'number', width: 120 },
    { field: 'start_latitude', headerName: 'Start Lat', type: 'number', width: 100 },
    { field: 'start_longitude', headerName: 'Start Lon', type: 'number', width: 100 },
    { field: 'end_latitude', headerName: 'End Lat', type: 'number', width: 100 },
    { field: 'end_longitude', headerName: 'End Lon', type: 'number', width: 100 },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 100,
      getActions: ({ id }) => {
        return [
          <IconButton color="error" onClick={() => handleDeleteClick(id)}>
            <DeleteIcon />
          </IconButton>,
        ];
      },
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Typography variant="h4" sx={{ mb: 4 }}>Manage Rides</Typography>
      <DataGrid
        rows={rides}
        columns={columns}
        loading={loading}
        getRowId={(row) => row.id}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><p>Are you sure you want to delete this ride?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default RidesPage;